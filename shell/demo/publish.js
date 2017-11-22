var fs = require('fs');
var path = require('path');
var querystring = require('querystring');
var http = require('http');
var shell = require('shelljs');
var prompt = require('prompt');
var ora = require('ora');

// 记录登录的次数
var log_count = 0;
var encodedPassword = '';
// 开发模式or生产模式
var commitMess = Array.prototype.slice.call(process.argv, 2).join(' ') || 'modify';
var shellFileName = 'micode-publish-test.sh ',
    treeName = 'cn-test';

// 获取activity项目根路径、项目名称
var pathArr = path.parse(__dirname).dir.split('/');
var projectName = path.resolve(__dirname).replace(/.*\/m\//, '/p/');
pathArr.splice(pathArr.indexOf('m'));
var rootPath = pathArr.join('/').toString() + '/';

var homePath = pathArr.slice(0, 3).join('/').toString();
console.log(homePath)

// 提交代码并打tag
function commitCode() {
  shell.exec('sh ./shell/' + shellFileName + rootPath + ' ' + commitMess + '> /dev/null 2>&1', function(code, stdout, stderr) {
    if(code != 0) {
      if(code == 2) {
        console.log('合并分支时发生冲突，请手动解决');
      } else if(code == 1) {
        console.log('请切换到 feature 或 master 分支');
      }
    } else {
        shell.exec('sh ./shell/micode-tag.sh', function(code, stdout, stderr) {
          if(code == 1) {
            console.log('当前分支下有文件未提交');
          } else {
            console.log('新建的 tag 为：' + stdout);
            publishCodeToTest(stdout);
          }
        });
    }
  });
}

// 获取加密后的密码
function getEncodedPassword(name, psd) {
  var postData = querystring.stringify({
  'unencrypted' : psd
  });

  var options = {
    hostname: '10.236.12.113',
    port: 3000,
    path: '/cipher',
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Content-Length': Buffer.byteLength(postData)
    }
  };

  var req = http.request(options, (res) => {
    res.setEncoding('utf8');
    res.on('data', (chunk) => {
      encodedPassword = JSON.parse(chunk).data.encrypted;
      if(!fs.existsSync(homePath + '/activity-mi-com')) {
        fs.mkdirSync(homePath + '/activity-mi-com', 0777);
      }
      fs.writeFile(homePath + '/activity-mi-com/.userinfo.js', JSON.stringify([{name: name, password: encodedPassword}, {name: 'yangkai2', password: '42b49cc92e2e2d024dace22ce325336f'}]), function (err) {
        if (err) throw err;
        console.log("成功记录你的用户名、密码！下面开始发布...");
        commitCode();
      });
    });
    res.on('end', () => {});
  });

  req.on('error', (e) => {
    console.log(`problem with request: ${e.message}`);
  });

  req.write(postData);
  req.end();
}

// 发布代码到服务器
function publishCodeToTest(new_tag) {
  var formatTag = new_tag.trim();
  fs.readFile(homePath + '/activity-mi-com/.userinfo.js', 'utf8', (err, data) => {
    if (err) throw err;
    // 登录失败超过两次，用老人家的账号发布
    try {var username = JSON.parse(data)[(log_count == 0 || log_count == 1) ? 0 : 1].name} catch(e) {var username = JSON.parse(data).name};
    try {var password = JSON.parse(data)[(log_count == 0 || log_count == 1) ? 0 : 1].password} catch(e) {var password = JSON.parse(data).password};
    console.log(username + ' ' + password);
    var postData = querystring.stringify({
      'username': username,
      'password': password,
      'project': 'h5-mi-com',
      'tree': treeName,
      'tag': formatTag
    });

    var options = {
      hostname: '10.236.12.113',
      port: 3000,
      path: '/chaos/publish',
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Content-Length': Buffer.byteLength(postData)
      }
    };
    var spinner = ora('开始发布代码到测试环境...').start();
    setTimeout(() => {
      spinner.color = 'yellow';
      spinner.text = '正在发布代码到测试环境，请稍后...';
    }, 1000);
    var req = http.request(options, (res) => {
      res.setEncoding('utf8');
      res.on('data', (chunk) => {
        var log_mess = ''
        var res = JSON.parse(chunk).status;
        var tagName = JSON.parse(chunk).data.tagName;
        switch(res.code) {
          case 0:
            log_mess = '已发布的tag为：' + tagName;
            console.log('\n项目地址：' + 'https://h5.test.mi.com' + projectName + '/index.html');
            break;
          case 1:
            log_mess = '传的参数不全';
            break
          case 2:
            log_mess = '密码解密失败';
            break;
          case 3:
            log_mess = '没有权限';
            break;
          case 4:
            log_mess = '接口超时';
            break;
          case 5:
            log_mess = '没有匹配到已存储的项目ID';
            break;
          case 7:
            log_mess = '发布时间过长，可能是代理服务器参数错误或Chaos服务器运行出错，请登录https://chaos.pf.xiaomi.com 自行检查';
            break;
          case 8:
            log_mess = '项目仍在发布中，请稍等，或请登录https://chaos.pf.xiaomi.com 查看状态';
            break;
          case 9:
            log_mess = '服务端返回超时';
            break;
          case 11:
            // log_mess = '登录出问题了，服务端问题，请重试';
            log_count++;
            publishCodeToTest();
            break;
          case 6:
          case 10:
          case 12:
            // log_count = 0;
            setTimeout(function() {
              publishCodeToTest(new_tag);
            }, 6e4);
            break;
          default:
            log_mess = '未知错误';
        }
        console.log('\n' + log_mess);
      });
      res.on('end', () => {
        spinner.stop();
      });
    });

    req.on('error', (e) => {
      console.log(`problem with request: ${e.message}`);
    });

    req.write(postData);
    req.end();
  });

}

// 增加用户名、密码
function addUserInfo() {
  var schema = {
    properties: {
      name: {
        pattern: /^[a-z]+[0-9]*$/,
        message: '用户名只能是小写字母或小写字母＋数字（你的邮箱前缀）',
        required: true,
        description: '请输入您的邮箱前缀'
      },
      password: {
        hidden: true,
        description: '请输入您的邮箱密码(保存的是加密后的哦)'
      }
    }
  };
  prompt.start();
  prompt.get(schema, function (err, result) {
    getEncodedPassword(result.name, result.password);
  });
}


if (!shell.which('git')) {
  shell.echo('Sorry, this script requires git');
  shell.exit(1);
} else {
    fs.stat(homePath + '/activity-mi-com/.userinfo.js', function(err, stats) {
      if(err) {
        addUserInfo();
      } else {
        console.log('正在提交代码...');
        commitCode();
      }
    });
}



