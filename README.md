# 概要
Arduinoのローカル環境構築をスキップする用のリポジトリです。<br>
# 環境構築手順
1. Dockerをインストール
2. VsCodeをインストール
3. ソースをクローン
4. VsCodeの拡張機能にDevContainersをインストール
5. Ctrl Shift Pでコマンドパレットを開く
6. DevContainer:Reopen in Containerを押下

# デバッグ方法
CLIでtask cを実行→ブレークポイントを設置→Ctrl Shift Dでデバッグバーを開く→Launchを選んで起動でブレークポイントで止まります。

サンプルコード
``` main.c
#include <stdio.h>

int add(int a, int b) {
    int result = a + b;  // ここにブレークポイントを置いてみるとわかりやすい
    return result;
}

int main(void) {
    int x = 3;
    int y = 4;

    printf("x = %d, y = %d\n", x, y);

    int sum = add(x, y);

    printf("sum = %d\n", sum);

    // ループにもブレークポイントを置いてみる
    for (int i = 0; i < 5; i++) {
        printf("i = %d\n", i);
    }

    return 0;
}

```