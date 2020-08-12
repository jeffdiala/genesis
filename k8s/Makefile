NAMESPACE ?= oms
IMG_NAME ?= oms/base-service

CI_PIPELINE_IID ?= $$(date +'%y%m%d%H%M')
# version based tags
# denotes a tag originated from last annotated tag
DIFF_TAG ?= ${shell git rev-parse --short HEAD}
# denotes a proper tag, used for production image tagging
PRD_TAG ?= ${shell git rev-parse --short HEAD}
DEV_TAG ?= ${DIFF_TAG}-${CI_PIPELINE_IID}
TAG		?= $$(git log -1 --pretty=%h)

# projects
DEV_PROJECT ?= beda-oms-dev
STG_PROJECT ?= beda-oms-stg
PRD_PROJECT ?= beda-oms-prd

# image paths
GCP_REGISTRY_HOST ?= gcr.io
DEV_IMG_PATH ?= ${GCP_REGISTRY_HOST}/${DEV_PROJECT}/${IMG_NAME}
STG_IMG_PATH ?= ${GCP_REGISTRY_HOST}/${STG_PROJECT}/${IMG_NAME}
PRD_IMG_PATH ?= ${GCP_REGISTRY_HOST}/${PRD_PROJECT}/${IMG_NAME}

# images
DEV_IMG ?= ${DEV_IMG_PATH}:${DEV_TAG}
STG_IMG ?= ${STG_IMG_PATH}:${DEV_TAG}
PRD_IMG ?= ${PRD_IMG_PATH}:${PRD_TAG}
LATEST_STG_IMG ?= ${STG_IMG_PATH}:latest

# temp dir
TMP_DIR ?= $(shell pwd)/tmp/

# configuration tasks
configure_namespace:
	@ echo "Setting ${NAMESPACE} as context"
	@ kubectl config set-context --current --namespace=${NAMESPACE}

# should only be invoked by ci-cd pipeline
configure:
	@ gcloud auth activate-service-account --key-file ${GCLOUD_SA_KEY}
	@ gcloud container clusters get-credentials ${cluster} ${location} --project ${project}
	@ kubectl config set-context --current --namespace=${NAMESPACE}
# end - configuration tasks

# docker image build tasks
# build a docker image with dev env tag, the same image will be
# promoted to stg and prd in release flow.
.PHONY: build
build:
	@ echo "Building docker image for version ${DEV_TAG}"
	@ docker build -t ${DEV_IMG} . --build-arg BUILD_ENV=development

.PHONY: build-no-cache
build-no-cache:
	@ echo "Building docker image for version ${DEV_TAG} with no cache"
	@ docker build --no-cache -t ${DEV_IMG} . --build-arg BUILD_ENV=development
# end - docker image build tasks

# docker publish image tasks
.PHONY: publish_dev
publish_dev: build
	@ echo "Publishing image to dev registry"
	@ docker push ${DEV_IMG}
	@ echo "Done publishing: ${DEV_IMG}"

# this step - instead of building again, promotes the same image
# the version tag remains the same as dev but with different registry
# url.
.PHONY: publish_stg
publish_stg:
	@ echo "Promoting dev image to stg registry"
	@ gcloud container images add-tag ${DEV_IMG} ${STG_IMG}  --quiet
	# this helps during prd promotion to tag latest stg image
	@ gcloud container images add-tag ${DEV_IMG} ${LATEST_STG_IMG}  --quiet
	@ echo "Done promoting: ${DEV_IMG} to: ${STG_IMG} and ${LATEST_STG_IMG}"

# since production publish is initiated via tags, at that moment it overrides
# the tag that was used in stg and dev, obtained via git describe. hence it has
# to be fetched from registry and used from there.
.PHONY: publish_prd
publish_prd:
	@ echo "Promoting latest stg image to prd registry with final tag: ${PRD_TAG}"
	@ gcloud container images add-tag ${LATEST_STG_IMG} ${PRD_IMG}  --quiet
	@ echo "Done promoting: ${LATEST_STG_IMG} to: ${PRD_IMG}"
# end - docker publish image tasks

# k8s deployment tasks
install:
	@ echo "Deploying webapp image: ${IMG} into ${env} cluster"
	@ kustomize build kustomize/overrides/${env} |\
	  sed 's|IMAGE_PLACEHOLDER|${IMG}|g' | kubectl apply -f -

install_dev:
	@ $(MAKE) install env=dev IMG=${DEV_IMG}

install_stg:
	@ $(MAKE) install env=stg IMG=${STG_IMG}

install_prd:
	@ $(MAKE) install env=prd IMG=${PRD_IMG}

## ADMIN COMMANDS ##
# Warning: these commands are used and should be used with care and only
# when absolute necessary.

# cleans all the k8s resources under the service namespace in cluster
clean:
	@ echo "Deleting all resources from k8s cluster"
	@ kubectl config set-context --current --namespace=${NAMESPACE}
	@ kubectl delete namespace ${NAMESPACE}

# restarts the service; useful when some secrets are updated.
restart:
	@ echo "Restarting the services by recreating the pods"
	@ kubectl scale --replicas=0 deployment/oms-deployment
	@ kubectl scale --replicas=2 deployment/oms-deployment

# useful when cert is updated or compute address associated with
# ingress is updated.
recreate_ingress:
	@ echo "Recreating ingress for ${env}"
	@ kubectl delete -f deployment/overrides/${env}/ingress.yml
	# uncomment following lines when cert.yml files are in place.
	# @ kubectl delete -f deployment/overrides/${env}/config/cert.yml
	# @ kubectl apply -f deployment/overrides/${env}/config/cert.yml
	@ kubectl apply -f deployment/overrides/${env}/ingress.yml

# cleans everything under service namespace and redeploys.
reinstall:
	@ echo "Redeploying for ${env} cluster"
	@ make clean configure_namespace install_${env}
# end - k8s deployment tasks

# local

# runs the built image in local docker
run_local: build
	@ echo "Running ${DEV_IMG} locally"
	@ docker run --env-file ${env_file} -p 9000:9000 ${DEV_IMG} --network=host
# runs the service in local minikube cluster
install_local:
	@ $(MAKE) install env=local IMG=${DEV_IMG}


.PHONY: help
help: ## - Show help message
	@ printf "\033[32m\xE2\x9c\x93 usage: make [target]\n\n\033[0m"
	@ grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: test
test: ## - Run testing and and create cover.out and cover.html
	@ printf "\033[32m\xE2\x9c\x93 Run testing and and create cover.out and cover.html files\n\033[0m"
	@ ./gradlew clean
	@ ./gradlew test


# End Command for machine local