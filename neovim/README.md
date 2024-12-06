## Cursor で NeoVim のセッティングをする手順

1. 下記のコマンドで `Packer` をインストールします

```sh
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
```

2. nvim ディレクトリを開き、`PackerInstall` のコマンドを叩く
3. Cursor で VScode Neovim のプラグインをインストールする
4. Cursor のキーバインド設定を変更する

```json
// 既定値を上書きするには、このファイル内にキー バインドを挿入しますauto[]
[
  {
    "command": "vscode-neovim.compositeEscape1",
    "key": "j",
    "when": "neovim.mode == insert && editorTextFocus",
    "args": "j"
  },
  {
    "command": "workbench.action.terminal.new",
    "key": "t",
    "when": "neovim.mode == normal && editorTextFocus"
  },
  {
    "command": "vscode-neovim.send",
    "key": "d l",
    "args": "d$",
    "when": "neovim.mode == normal && editorTextFocus"
  },
  {
    "command": "vscode-neovim.send",
    "key": "d h",
    "args": "d0",
    "when": "neovim.mode == normal && editorTextFocus"
  },
  {
    "command": "vscode-neovim.send",
    "key": "space h",
    "args": "^",
    "when": "neovim.mode == normal && editorTextFocus"
  },
  {
    "command": "vscode-neovim.send",
    "key": "space l",
    "args": "$",
    "when": "neovim.mode == normal && editorTextFocus"
  },
  {
    "command": "vscode-neovim.send",
    "key": "v v",
    "args": ":vsp<Enter>",
    "when": "neovim.mode == normal && editorTextFocus"
  },
  {
    "command": "vscode-neovim.send",
    "key": "v l",
    "args": "<C-w>l",
    "when": "neovim.mode == normal && editorTextFocus"
  },
  {
    "command": "vscode-neovim.send",
    "key": "v h",
    "args": "<C-w>h",
    "when": "neovim.mode == normal && editorTextFocus"
  },
  {
    "command": "vscode-neovim.send",
    "key": ",",
    "args": ",<Space>",
    "when": "neovim.mode == insert && editorTextFocus"
  },
  {
    "command": "editor.action.goToDeclaration",
    "key": "r k",
    "when": "neovim.mode == normal && editorTextFocus"
  },
  {
    "command": "workbench.action.navigateBack",
    "key": "b k",
    "when": "neovim.mode == normal && editorTextFocus"
  },
  {
    "command": "editor.action.referenceSearch.trigger",
    "key": "space k",
    "when": "neovim.mode == normal && editorTextFocus"
  },
  {
    "key": "; f",
    "command": "workbench.action.quickOpen",
    "when": "neovim.mode == normal && editorTextFocus"
  },
  {
    "key": "; r",
    "command": "workbench.action.findInFiles",
    "when": "neovim.mode == normal && editorTextFocus"
  },
  {
    "command": "vscode-neovim.send",
    "key": "d w",
    "args": "dw",
    "when": "neovim.mode == normal && editorTextFocus"
  },
  {
    "command": "vscode-neovim.send",
    "key": "d d",
    "args": "dd",
    "when": "neovim.mode == normal && editorTextFocus"
  },
  {
    "command": "vscode-neovim.send",
    "key": "v i",
    "args": "vi",
    "when": "neovim.mode == normal && editorTextFocus"
  },
  {
    "command": "vscode-neovim.send",
    "key": "b",
    "args": "b",
    "when": "neovim.mode == normal && editorTextFocus"
  },
  {
    "command": "vscode-neovim.send",
    "key": "ctrl+k",
    "args": "kk",
    "when": "neovim.mode == insert && editorTextFocus"
  },
  {
    "command": "vscode-neovim.send",
    "key": "r i",
    "args": "ri",
    "when": "neovim.mode == normal && editorTextFocus"
  },
  {
    "command": "vscode-neovim.send",
    "key": "r f",
    "args": "rf",
    "when": "neovim.mode == normal && editorTextFocus"
  },
  {
    "command": "editor.action.marker.next",
    "key": "shift+e",
    "when": "neovim.mode == normal && editorTextFocus"
  },
  {
    "command": "editor.action.marker.prev",
    "key": "ctrl+e",
    "when": "neovim.mode == normal && editorTextFocus"
  },
  {
    "command": "workbench.action.navigateBack",
    "key": "n b",
    "when": "editorTextFocus && neovim.mode == normal"
  },
  {
    "command": "workbench.action.focusSideBar",
    "key": "f s",
    "when": "editorTextFocus && neovim.mode == normal"
  },
  {
    "command": "workbench.action.terminal.focusNextPane",
    "key": "shift alt ctrl"
  },
  {
    "command": "editor.action.addSelectionToNextFindMatch",
    "key": "ctrl+d",
    "when": "editorTextFocus && neovim.init"
  },
  {
    "key": "tab",
    "command": "github.copilot.acceptCursorPanelSolution",
    "when": "github.copilot.activated && github.copilot.panelVisible"
  },
  {
    "key": "ctrl+/",
    "command": "-github.copilot.acceptCursorPanelSolution",
    "when": "github.copilot.activated && github.copilot.panelVisible"
  },
  {
    "key": "ctrl+v",
    "command": "workbench.action.terminal.split",
    "when": "terminalFocus"
    // ターミナルを分割する
  },
  {
    "key": "ctrl+t",
    "command": "workbench.action.terminal.toggleTerminal",
    "when": "neovim.mode === normal || terminalFocus"
    // ターミナルの表示/非表示を切り替える
  },

  {
    "key": "ctrl+k",
    "command": "workbench.action.terminal.kill",
    "when": "terminalFocus"
    // 起動しているターミナルを閉じる
  },
  {
    "key": "ctrl+m",
    "command": "workbench.action.terminal.focusNextPane",
    "when": "terminalFocus"
    // 分割しているターミナルのフォーカスを切り替える
  },
  {
    "key": "alt",
    "command": "editor.action.insertCursorAtEndOfEachLineSelected",
    "when": "editorTextFocus"
  },
  {
    "key": "shift+alt+i",
    "command": "-editor.action.insertCursorAtEndOfEachLineSelected",
    "when": "editorTextFocus"
  },
  {
    "key": "ctrl+cmd+[",
    "command": "editor.foldAll",
    "when": "editorTextFocus && foldingEnabled"
  },
  {
    "key": "cmd+r cmd+0",
    "command": "-editor.foldAll",
    "when": "editorTextFocus && foldingEnabled"
  },
  {
    "key": "ctrl+cmd+]",
    "command": "editor.unfoldAll",
    "when": "editorTextFocus && foldingEnabled"
  },
  {
    "key": "cmd+r cmd+j",
    "command": "-editor.unfoldAll",
    "when": "editorTextFocus && foldingEnabled"
  },
  {
    "key": "cmd+[",
    "command": "editor.fold",
    "when": "editorTextFocus && foldingEnabled"
  },
  {
    "key": "alt+cmd+[",
    "command": "-editor.fold",
    "when": "editorTextFocus && foldingEnabled"
  },
  {
    "key": "cmd+]",
    "command": "editor.unfold",
    "when": "editorTextFocus && foldingEnabled"
  },
  {
    "key": "alt+cmd+]",
    "command": "-editor.unfold",
    "when": "editorTextFocus && foldingEnabled"
  }
]
```
