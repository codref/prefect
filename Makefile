SHELL := bash
TMPDIR := $(shell mktemp -d)
export registry=gitlab.evouser.com:5005
export apiv4url=https://gitlab.evouser.com/api/v4
export image=infrastructure/prefect
export projectID=1198
export version=$(shell cat ./VERSION)
export distSearchPattern=$(TMPDIR)/prefect*/

all: build

build:
	docker build --build-arg PYTHON_VERSION=3.9 --build-arg BUILD_PYTHON_VERSION=3.9 -t $(registry)/$(image):$(shell cat ./VERSION) .
	docker build --build-arg PYTHON_VERSION=3.9 --build-arg BUILD_PYTHON_VERSION=3.9 -t $(registry)/$(image):latest .

push:
	docker push $(registry)/$(image):$(shell cat ./VERSION)
	docker push $(registry)/$(image):latest

build_pipy_package:
	docker run --rm $(registry)/$(image):$(shell cat ./VERSION) tar -cC /opt/prefect/dist . | tar -m --no-overwrite-dir -xC $(TMPDIR)
	TWINE_PASSWORD=$(GITLAB_TOKEN) TWINE_USERNAME=pypi-token python -m twine upload --verbose --repository-url $(apiv4url)/projects/$(projectID)/packages/pypi $(TMPDIR)/*