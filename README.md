# Go Script Runner

Go Script Runner 是一个用Go语言编写的高效定时任务管理器。它能够递归扫描指定目录下的脚本文件，根据文件名中指定的时间间隔定期执行这些脚本。该程序支持通过命令行参数传递目录路径，并且可以在Docker和systemd环境中运行。

## 特性

- **递归扫描**：自动递归扫描指定目录及其子目录中的脚本文件。
- **定时执行**：根据文件名中的时间间隔定期执行脚本。
- **超时控制**：每个脚本执行的超时时间为脚本间隔和5分钟中的最小值。
- **Docker 支持**：提供Dockerfile，可以轻松构建和运行Docker容器。
- **systemd 支持**：提供systemd单元文件，可以作为系统服务运行。
- **日志记录**：将脚本执行的输出和错误记录到系统日志中。

## 安装

### 从源码编译

1. 克隆代码库：

    ```sh
    git clone https://github.com/onewesong/go-script-runner.git
    cd go-script-runner
    ```

2. 编译程序：

    ```sh
    go build -o go-script-runner .
    ```

### Docker

1. 构建Docker镜像：

    ```sh
    docker build -t go-script-runner .
    ```

2. 运行Docker容器：

    ```sh
    docker run --name go-script-runner -v /path/to/your/scripts:/app/scripts go-script-runner
    ```

### systemd

1. 创建systemd单元文件 `/etc/systemd/system/go-script-runner.service`：

    ```ini
    [Unit]
    Description=Go Script Runner Service
    After=network.target

    [Service]
    WorkingDirectory=/path/to/your/app
    ExecStart=/path/to/your/app/go-script-runner -dir /path/to/your/scripts
    Environment="SCRIPT_DIR=/path/to/your/scripts"
    Restart=always
    RestartSec=5
    Type=simple
    StandardOutput=syslog
    StandardError=syslog
    SyslogIdentifier=go-script-runner

    [Install]
    WantedBy=multi-user.target
    ```

2. 重新加载systemd配置并启用服务：

    ```sh
    sudo systemctl daemon-reload
    sudo systemctl enable go-script-runner
    sudo systemctl start go-script-runner
    ```

## 使用

运行程序并指定脚本目录：

```sh
./go-script-runner -dir /path/to/your/scripts
```


### 目录结构
确保你的脚本文件名符合 interval_xxx 格式，例如 10_backup.sh，其中 10 表示每10秒执行一次。一个示例项目结构如下：
```
.
└── scripts
    └── test
        ├── 3600_test.py
    ├── 10_backup.sh
    └── 60_cleanup.sh
```