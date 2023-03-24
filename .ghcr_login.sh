export CR_PAT=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
export CR_USER="bokhanych"
echo $CR_PAT | docker login ghcr.io -u $CR_USER --password-stdin