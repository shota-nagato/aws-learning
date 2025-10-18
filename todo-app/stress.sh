#!/bin/bash

# ストレステスト用スクリプト
# 20ラウンド実行し、毎ラウンドで20並列のリクエストを送る

for i in {1..20}; do
  echo "Round $i"

  # 20並列で非同期リクエスト送信
  for j in {1..20}; do
    curl -s https://api.dev.yuyan-lab.com/public/stress &
  done

  # 全てのバックグラウンド処理が終わるまで待機
  wait

  # 少し休んで次のラウンドへ
  sleep 5
done

echo "Stress test complete!"
