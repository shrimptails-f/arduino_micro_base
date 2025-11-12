# 概要  
Arduino microのローカル環境構築をスキップする用のリポジトリです。  
# 言語・環境
- 言語: C++
- ローカル環境: Docker、DevContainer
- Docker イメージ: gcc
- プログラム書き込み: arduino-cli 

# 環境構築手順   
## 1 arduino microにプログラムを書き込む環境整備  
### 1.1 Windows側コマンドインストール  
#### 1.1.1 usbipd インストール  
PowerShellを管理者権限で開く
```sh
winget install --interactive --exact dorssel.usbipd-win

以下を聞かれるのでYを押下しEnter
すべてのソース契約条件に同意しますか? [Y] はい [N] いいえ:
```
↓インストール完了表示
```
インストーラーハッシュが正常に検証されました
パッケージのインストールを開始しています...
インストールが完了しました
```
インストール確認
```
usbipd version

こんなのが出ればOK
PS C:\WINDOWS\system32> usbipd --version
5.3.0-54+Branch.master.Sha.aa3d
```
### 1.2 WSL2側コマンドインストール  
#### 1.2.1 usbipdインストール  
```
sudo apt update
sudo apt install -y linux-tools-virtual hwdata
sudo update-alternatives --install /usr/local/bin/usbip usbip /usr/lib/linux-tools/*/usbip 20
```
インストール確認
```
usbipd version

# 環境によっては以下のような警告が出ますが、無視して問題ありません。
WARNING: usbipd not found for kernel 6.6.87.2-microsoft
```
#### 1.2.2 arduino-cliインストール
```
curl -fsSL https://downloads.arduino.cc/arduino-cli/arduino-cli_latest_Linux_64bit.tar.gz -o arduino-cli.tar.gz
tar -xzf arduino-cli.tar.gz
sudo mv arduino-cli /usr/local/bin/
```
インストール確認
```
rduino-cli version

arduino-cli  Version: 1.3.1 Commit: 08ff7e2b Date: 2025-08-28T13:51:45Z
```
## 2 DevContainer起動
1. Dockerをインストール
2. VsCodeをインストール
3. ソースをクローン
4. VsCodeの拡張機能にDevContainersをインストール
5. Ctrl Shift Pでコマンドパレットを開く
6. DevContainer:Reopen in Containerを押下

# Arduino microへプログラム書き込み
## プログラムファイル準備
プロジェクトルート直下に以下のファイルを用意します
```
src
├── src.ino 
└── main.cpp
```
main.cppの内容
```cpp
#include <Arduino.h> 

void setup() {
    // 基板上のLEDピンを出力に設定
    pinMode(LED_BUILTIN, OUTPUT);
}

// 不規則に点滅させる
void loop() {
    digitalWrite(LED_BUILTIN, HIGH);
    delay(1000);
    digitalWrite(LED_BUILTIN, LOW);
    delay(1000);
    digitalWrite(LED_BUILTIN, HIGH);
    delay(50);
    digitalWrite(LED_BUILTIN, LOW);
    delay(50);
    digitalWrite(LED_BUILTIN, HIGH);
    delay(50);
    digitalWrite(LED_BUILTIN, LOW);
    delay(50);
}
```
## Windows側でCOM確認  
Windowsデバイスマネージャーで確認できる。  
抜き差しして消えたり出たりするものを確認すると確実  
これでWindows側は検出できているということになる  
![a](docs/device_manager.png)  
## usbipdの認識確認
先程のCOMの番号が表示できていればOk  
usbipdがArduinoを認識できているということになる。  
```
＃in PowerShell
PS C:\WINDOWS\system32> usbipd list
Connected:
BUSID  VID:PID    DEVICE                                                        STATE
3-2    1111:11111  USB シリアル デバイス (COM5)                                  Shared

Persisted:
GUID                                  DEVICE
ここには何も表示されなかった。
```
### USBデバイスへ接続
```
＃in PowerShell
usbipd attach --wsl --busid 3-2 --auto-attach
``` 
これでArduinoに接続した状態がWSLに転送される。
```
usbipd: info: Using WSL distribution 'Ubuntu' to attach; the device will be available in all WSL 2 distributions.
usbipd: info: Detected networking mode 'nat'.
usbipd: info: Using IP address 172.000.000.1 to reach the host.
usbipd: info: Starting endless attach loop; press Ctrl+C to quit.
WSL Monitoring host 172.000.000.1 for BUSID: 3-2
WSL 2025-11-12 10:38:11 Device 3-2 is available. Attempting to attach...
WSL 2025-11-12 10:38:11 Attach command for device 3-2 succeeded.
WSL 2025-11-12 10:38:19 Device 3-2 is now attached.
WSL 2025-11-12 10:40:11 Device 3-2 is now detached.
WSL 2025-11-12 10:40:11 Device 3-2 is available. Attempting to attach...
WSL 2025-11-12 10:40:11 Attach command for device 3-2 succeeded.
```
### プログラム書き込み
※DevContainer内からプログラムを書き込まない理由は、何度かconnectionを貼り直すせいで不安定すぎたため。
```
＃in WSL2 CLI

# WSL2でのデバイス名称確認
ls -l /dev/ttyACM*
> crw-rw---- 1 root dialout 166, 0 Nov 12 10:38 /dev/ttyACM0

上記コマンドのttyACM▲▲を控えておく

arduino-cli compile -b arduino:avr:micro ./src/
arduino-cli upload -b arduino:avr:micro -p /dev/ttyACM0 .
# /dev/ttyACM0のところは控えておいたものに置き換えてください。
```
プログラム書き込みコマンドのログ
```
Connecting to programmer: .
Found programmer: Id = "CATERIN"; type = S
    Software Version = 1.0; No Hardware Version given.
Programmer supports auto addr increment.
Programmer supports buffered memory access with buffersize=128 bytes.

Programmer supports the following devices:
    Device code: 0x44

New upload port: /dev/ttyACM0 (serial)
```

これでプログラムの書き込みが完了しました。  
点滅が確認できたら完了です。  
お疲れ様でした。  
## プログラムファイル作成時の注意点  
### ファイル名について  
ディレクトリと同名の.inoファイルが必要です。
```
src
├── src.ino // ディレクトリ名称.inoとし、内容は空でもok
└── main.cpp // こちらにメインプログラムを記載
             // .cでも良いが、本リポジトリはC言語用に整備されていません。
```
# デバッグ方法
CLIでtask cを実行→ブレークポイントを設置→Ctrl Shift Dでデバッグバーを開く→Launchを選んで起動でブレークポイントで止まります。

サンプルコード  
main.c
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