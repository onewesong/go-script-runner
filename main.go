package main

import (
	"context"
	"flag"
	"io/fs"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strconv"
	"time"
)

// 脚本信息结构体
type Script struct {
	Interval time.Duration
	Path     string
}

// 递归读取目录中的所有可执行脚本文件
func loadScripts(directory string) ([]Script, error) {
	var scripts []Script
	re := regexp.MustCompile(`^(\d+)_.*`)

	err := filepath.WalkDir(directory, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if !d.IsDir() {
			matches := re.FindStringSubmatch(d.Name())
			if len(matches) == 2 {
				interval, err := strconv.Atoi(matches[1])
				if err != nil {
					log.Printf("Invalid interval in filename %s: %v", d.Name(), err)
					return nil
				}
				// 检查文件是否可执行
				if isExecutable(path) {
					scripts = append(scripts, Script{
						Interval: time.Duration(interval) * time.Second,
						Path:     path,
					})
				}
			}
		}
		return nil
	})

	if err != nil {
		return nil, err
	}

	return scripts, nil
}

// 检查文件是否可执行
func isExecutable(path string) bool {
	info, err := os.Stat(path)
	if err != nil {
		return false
	}
	return info.Mode().Perm()&(1<<(uint(7))) != 0
}

// 执行脚本
func runScript(script Script) {
	for {
		log.Printf("Executing script: %s", script.Path)
		timeout := script.Interval
		if timeout > 5*time.Minute {
			timeout = 1 * time.Minute
		}
		go func() {
			ctx, cancel := context.WithTimeout(context.Background(), timeout)
			defer cancel()

			cmd := exec.CommandContext(ctx, script.Path)
			output, err := cmd.CombinedOutput()
			if ctx.Err() == context.DeadlineExceeded {
				log.Printf("Script %s timed out", script.Path)
			} else if err != nil {
				log.Printf("Error executing script %s: %v", script.Path, err)
			} else {
				log.Printf("Output of script %s: %s", script.Path, string(output))
			}
		}()
		time.Sleep(script.Interval)
	}
}

func main() {
	// 从命令行参数获取目录
	directory := flag.String("dir", "./scripts", "directory containing the scripts")
	flag.Parse()

	scripts, err := loadScripts(*directory)
	if err != nil {
		log.Fatalf("Failed to load scripts: %v", err)
	}

	for _, script := range scripts {
		go runScript(script)
	}

	// 防止主线程退出
	select {}
}
