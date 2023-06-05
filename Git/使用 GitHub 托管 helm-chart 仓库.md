# 使用 GitHub 托管 helm-chart 仓库

helm 官方文档：

- [Helm | Chart Releaser Action to Automate GitHub Page Charts](https://helm.sh/docs/howto/chart_releaser_action/)

1. 创建 GitHub 仓库，例如：`helm-charts`，克隆到本地。

```bash
git clone git@github.com:poneding/helm-charts.git
cd helm-charts
```

2. 创建干净的 `gh-pages` 分支。

```bash
git checkout --orphan gh-pages
git rm -rf .
vim README.md
```

````markdown
# helm-charts

## Usage

[Helm](https://helm.sh) must be installed to use thecharts.  Please refer to
Helm's [documentation](https://helm.sh/docs) to getstarted.

Once Helm has been set up correctly, add the repo asfollows:

```bash
helm repo add mycharts https://poneding.github.iohelm-charts
```

If you had already added this repo earlier, run `helm repoupdate` to retrieve
the latest versions of the packages.  You can then run`helm search repo
mycharts` to see the charts.

To install the mycharts chart:

```bash
helm install myapp mycharts/myapp
```

To uninstall the chart:

```bash
helm uninstall myapp
```
````

```bash
git add .
git commit -am "add README.md"
git push -u origin gh-pages
```

3. 仓库启用 GitHub Pages 功能，选择 `gh-pages` 分支。

4. charts 开发。

```bash
git checkout master
mkdir charts
cd charts
helm create myapp
cd ..
```

5. 使用 GitHub Action 搭配 chart-releaser 功能，为我们自动发布 charts 版本。

```bash
mkdir -p .github/workflows
vim .github/workflows/release-chart.yaml
```

```bash
name: Release Charts

on:
  push:
    branches:
      - master

jobs:
  release:
    # depending on default permission settings for your org (contents being read-only or read-write for workloads), you will have to add permissions
    # see: https://docs.github.com/en/actions/security-guides/automatic-token-authentication#modifying-the-permissions-for-the-github_token
    permissions:
      contents: write
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Configure Git
        run: |
          git config user.name poneding
          git config user.email poneding@gmail.com

      - name: Install Helm
        uses: azure/setup-helm@v3

      - name: Run chart-releaser
        uses: helm/chart-releaser-action@v1.5.0
        with:
          charts_dir: charts
          charts_repo_url: https://poneding.github.io/helm-charts
        env:
          CR_TOKEN: "${{ secrets.GH_TOKEN }}"
```

> 需要提前将 GitHub Token 生成出来，并配置到仓库的 Secrets 中。

1. 提交代码即可第一次发版。

2. 之后对 charts 改动后，修改 `Chart.yaml` 中的 `version` 字段，helm-releaser 会检测版本改动，并自动发版。

