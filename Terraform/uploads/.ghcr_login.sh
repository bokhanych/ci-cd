export PAT=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
export GIT_USER=bokhanych

echo $PAT | docker login ghcr.io --username $GIT_USER --password-stdin
