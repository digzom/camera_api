#!/bin/sh
/app/bin/camera_api eval "CameraApi.Release.migrate"
/app/bin/camera_api eval "CameraApi.Release.seed"
/app/bin/server
