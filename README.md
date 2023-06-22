# ros_base

## Build

```bash
docker build -t rdrobotics/ros2:latest .
```

## test
```bash
docker run --net host rdrobotics/ros2:latest bash
# some ros-command
```