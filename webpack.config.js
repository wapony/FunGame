const path = require('path')

module.exports = {
    entry: './src/js/main.js',
    output: {
        filename: 'bundle.js',
        path: path.join(__dirname, './build')
    },
    mode: 'development',
    devServer: {
        contentBase: './src',       // 指定默认从那个文件夹读取index.html
        open: true
    },
    module: {
        rules: [
            {
                test: /\.css/,
                use: ['style-loader', 'css-loader']
            }
        ]
    }
}