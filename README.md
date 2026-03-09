# Google Drive 集成工具

用于从命令行访问 Google Drive 文档的 Python 工具，适用于研究资料管理和开题报告撰写。

## 快速开始

### 1. 安装依赖

```bash
pip install -r requirements.txt
```

### 2. 配置 Google Cloud 凭证

1. 前往 [Google Cloud Console](https://console.cloud.google.com/)
2. 创建项目（或选择已有项目）
3. 启用以下 API：
   - **Google Drive API**
   - **Google Docs API**
4. 进入 **APIs & Services → Credentials**
5. 点击 **Create Credentials → OAuth 2.0 Client ID**
6. 选择 **Desktop app** 类型
7. 下载 JSON 文件，重命名为 `credentials.json` 放到项目根目录

### 3. 首次认证

运行任意命令，程序会自动打开浏览器让你登录 Google 账号并授权：

```bash
python main.py list
```

授权成功后会自动生成 `token.json`（已在 .gitignore 中，不会被提交）。

## 使用方法

```bash
# 列出最近的文件
python main.py list

# 只列出 Google Docs
python main.py list --type doc

# 列出某个文件夹下的文件
python main.py list --folder FOLDER_ID

# 搜索文件
python main.py search "开题报告"

# 读取 Google Doc 的纯文本内容
python main.py read DOC_FILE_ID

# 下载文件（Google Docs 自动导出为 PDF）
python main.py download FILE_ID

# 查看文件元信息
python main.py info FILE_ID
```

## 项目结构

```
├── main.py                    # CLI 入口
├── requirements.txt           # Python 依赖
├── .gitignore                 # 忽略凭证文件
└── google_drive_tool/
    ├── __init__.py
    ├── auth.py                # OAuth2 认证
    └── drive.py               # Drive 文件操作
```
