#!/bin/bash
# 使用详细模式推送，查看具体问题

echo "开始推送，使用详细模式..."
echo "如果卡住，按 Ctrl+C 中断，然后查看输出"

# 设置详细模式
export GIT_CURL_VERBOSE=1
export GIT_TRACE=1
export GIT_TRACE_PACKET=1

# 推送
git push -u origin main 2>&1 | tee push_log.txt

echo ""
echo "推送完成或中断。日志已保存到 push_log.txt"

