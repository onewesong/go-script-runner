# Makefile for Go Script Runner

# 项目名称
APP_NAME = go-script-runner

# Go 源文件目录
SRC_DIR = .

# 构建目录
BUILD_DIR = ./build

# 脚本目录
SCRIPT_DIR = ./scripts

# Docker 镜像名称
DOCKER_IMAGE = $(APP_NAME)

# Go 编译器
GO = go

# Go 构建目标
BUILD_TARGET = $(BUILD_DIR)/$(APP_NAME)

# 默认目标
.PHONY: all
all: build

# 编译Go程序
.PHONY: build
build:
	@echo "Building $(APP_NAME)..."
	@mkdir -p $(BUILD_DIR)
	@$(GO) build -o $(BUILD_TARGET) $(SRC_DIR)

# 运行编译后的程序
.PHONY: run
run: build
	@echo "Running $(APP_NAME)..."
	@$(BUILD_TARGET) -dir $(SCRIPT_DIR)

# 构建Docker镜像
.PHONY: docker-build
docker-build:
	@echo "Building Docker image $(DOCKER_IMAGE)..."
	@docker build -t $(DOCKER_IMAGE) .

# 运行Docker容器
.PHONY: docker-run
docker-run: docker-build
	@echo "Running Docker container $(DOCKER_IMAGE)..."
	@docker run --name $(APP_NAME) -v $(shell pwd)/scripts:/app/scripts $(DOCKER_IMAGE)

# 清理生成的文件
.PHONY: clean
clean:
	@echo "Cleaning up..."
	@rm -rf $(BUILD_DIR)
	@docker rm -f $(APP_NAME) || true
	@docker rmi -f $(DOCKER_IMAGE) || true

# 打印帮助信息
.PHONY: help
help:
	@echo "Makefile for $(APP_NAME)"
	@echo
	@echo "Usage:"
	@echo "  make [target]"
	@echo
	@echo "Targets:"
	@echo "  build         Compile the Go program"
	@echo "  run           Run the compiled Go program"
	@echo "  docker-build  Build the Docker image"
	@echo "  docker-run    Run the Docker container"
	@echo "  clean         Clean up generated files"
	@echo "  help          Print this help message"

