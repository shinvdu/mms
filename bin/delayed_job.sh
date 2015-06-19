#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
RAILS_ENV=development $DIR/delayed_job -n 2 start

