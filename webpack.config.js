var path = require('path');
var webpack = require('webpack');
// var ExtractTextPlugin = require("extract-text-webpack-plugin");
// var exportsOfFile = require("livescript!./app/main.ls");
module.exports = {
    entry: {
        app: [
            "./app/main.ls"
        ]
    },
    output: {
        path: __dirname + '/build',
        filename: 'bundle.js',
    },
    devtool: "#inline-source-map",
    module: {
        loaders: [{
            test: /\.ls$/,
            exclude: /node_modules/,
            loader: "livescript",
            query: {
                map: 'embedded'
            }
        }, {
            test: /\.scss$/,
            loader: 'style!css!sass'
        }],
    },
        resolve: {
            extensions: ['', '.ls','.js','.jsx','.scss']
        }
};
