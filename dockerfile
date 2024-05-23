# 使用官方Go语言镜像作为构建阶段的基础镜像
FROM golang:1.22 AS builder

# 设置工作目录
WORKDIR /app

# 将当前目录的内容复制到工作目录中
COPY . .

# 编译Go程序
RUN go mod tidy
RUN go build -o /app/main .

# 使用更小的基础镜像创建最终镜像
FROM alpine:latest

RUN apk --no-cache add bash python3

# 设置工作目录
WORKDIR /app

# 从构建阶段复制编译后的二进制文件到最终镜像
COPY --from=builder /app/main .
COPY --from=builder /app/scripts ./scripts

# 暴露一个默认的环境变量目录位置
ENV SCRIPT_DIR /app/scripts

# 运行程序，使用ENTRYPOINT允许我们传递其他参数
ENTRYPOINT ["/app/main"]
CMD ["-dir", "/app/scripts"]
