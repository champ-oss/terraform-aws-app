set -e

# test if core and app can be paused via greenfield
# check if log groups are created on app ecs cluster
aws logs describe-log-groups \
  --log-group-name-prefix "${GIT}/paused" \
  | grep -q "${GIT}/paused"