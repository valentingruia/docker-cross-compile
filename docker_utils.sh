
clean_container() {
    local cnt="$1"

    if [ -z "$cnt" ]; then
        echo "Error: Please provide a container name."
        return 1
    fi

    # Extract the first 6 hex characters of the image ID (sha256 hash)
    local img
    img=$(docker inspect --format='{{.Image}}' "$cnt" 2>/dev/null | awk -F'sha256:' '{print substr($2, 1, 12)}')

    if [ -z "$img" ]; then
        echo "Error: Container '$cnt' not found."
        return 1
    fi

    echo "Stopping and removing container '$cnt'..."
    docker stop "$cnt" 2>/dev/null
    docker rm -f "$cnt"

    echo "Removing associated image '$img'..."
    docker rmi "$img"

    echo "Done!"
}

