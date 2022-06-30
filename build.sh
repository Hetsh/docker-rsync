#!/usr/bin/env bash


# Abort on any error
set -e -u

# Simpler git usage, relative file paths
CWD=$(dirname "$0")
cd "$CWD"

# Load helpful functions
source libs/common.sh
source libs/docker.sh

# Check access to docker daemon
assert_dependency "docker"
if ! docker version &> /dev/null; then
	echo "Docker daemon is not running or you have unsufficient permissions!"
	exit -1
fi

IMG_NAME="hetsh/rsync"
case "${1-}" in
	# Build and test with default configuration
	"--test")
		docker build \
			--tag "$IMG_NAME:test" \
			.

		# Create temporary directory
		TMP_DIR=$(mktemp -d "/tmp/$APP_NAME-XXXXXXXXXX")
		add_cleanup "rm -rf $TMP_DIR"

		# Host keys
		assert_dependency "ssh-keygen"
		ssh-keygen -q -t rsa -N "" -f "$TMP_DIR/ssh_host_rsa_key"
		ssh-keygen -q -t ecdsa -N "" -f "$TMP_DIR/ssh_host_ecdsa_key"
		ssh-keygen -q -t ed25519 -N "" -f "$TMP_DIR/ssh_host_ed25519_key"

		# Client keys
		CLIENT_KEY="$TMP_DIR/ssh_rsync_rsa_key"
		ssh-keygen -q -t rsa -N "" -f "$CLIENT_KEY"
		ln -s "$(basename $CLIENT_KEY).pub" "$TMP_DIR/authorized_keys"

		# Apply permissions
		extract_var APP_UID "./Dockerfile" "\d+"
		chown -R "$APP_UID" "$TMP_DIR"
		chmod 755 "$TMP_DIR"
		chmod 644 "$CLIENT_KEY"
		
		docker run \
			--rm \
			--tty \
			--interactive \
			--publish 22:22/tcp \
			--mount type=bind,source="$TMP_DIR",target=/rsync \
			--mount type=bind,source=/etc/localtime,target=/etc/localtime,readonly \
			"$IMG_NAME:test"
	;;
	# Build if it does not exist and push image to docker hub
	"--upload")
		if ! tag_exists "$IMG_NAME"; then
			docker build \
				--tag "$IMG_NAME:latest" \
				--tag "$IMG_NAME:$_NEXT_VERSION" \
				.
			docker push "$IMG_NAME:latest"
			docker push "$IMG_NAME:$_NEXT_VERSION"
			
			# Remove version for easier image cleanup
			docker image rm "$IMG_NAME:$_NEXT_VERSION"
		fi
	;;
	# Build image without additonal steps
	*)
		docker build \
			--tag "$IMG_NAME:latest" \
			.
	;;
esac
