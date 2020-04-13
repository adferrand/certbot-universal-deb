build:
	mkdir build
	curl -o build/python.tar.zst -L https://github.com/indygreg/python-build-standalone/releases/download/20200408/cpython-3.7.7-linux64-20200409T0045.tar.zst
	tar -I zstd -xvf build/python.tar.zst -C build
	cp -a build/python/install build/env
	git clone https://github.com/certbot/certbot.git --branch v1.3.0 --depth=1 --single-branch build/upstream
	build/env/bin/python3 build/upstream/tools/strip_hashes.py build/upstream/letsencrypt-auto-source/pieces/dependency-requirements.txt > build/constraints.txt
	build/env/bin/python3 build/upstream/letsencrypt-auto-source/pieces/pipstrap.py
	build/env/bin/python3 -m pip install build/upstream/acme build/upstream/certbot build/upstream/certbot-nginx build/upstream/certbot-apache -c build/constraints.txt
	find build/env/bin -type f -exec sed -i '1 s|^#!.*python.*|#!/usr/bin/env python3|' {} \;
	cp -a certbot-wrapper build

install: build
	mkdir -p $$(pwd)/debian/certbot/usr/share
	rm -rf $$(pwd)/debian/certbot/usr/share/certbot
	cp -av build/env $$(pwd)/debian/certbot/usr/share/certbot

clean:
	rm -rf build