#!/bin/bash

# 東京の天気情報を取得
weather=$(curl -s "wttr.in/Tokyo?format=%C+%t" 2>/dev/null)

# データが取得できない場合のフォールバック
if [[ -z "$weather" ]]; then
	weather="No Data"
fi

echo "󰖐 $weather"
