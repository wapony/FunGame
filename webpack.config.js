const path = require('path')

module.exports = {
    entry: {
        index: './src/js/main.js',
        about: './src/js/about.js',
        account: './src/js/account.js'
    },
    output: {
        filename: '[name].bundle.js',
        path: path.join(__dirname, './build')
    }, 
    devtool: 'cheap-module-eval-source-map',
    devServer: {
        contentBase: './src',       // 指定默认从那个文件夹读取index.html
        open: true
    },
    module: {
        rules: [
            {
                test: /\.css/,
                use: ['style-loader', 'css-loader']
            },
            {
                test: /\.m?js$/,
                exclude: /(node-modules|bower_components)/,
                use: {
                    loader: 'babel-loader',
                    options: {
                        presets: ['@babel/preset-env']
                    }
                }
            }
        ]
    }
}