// Description: 获取图书目录

// [展开所有章节]元素的匹配符号
const MATCHING_SYMBOLS_FOR_EXPANDING = ["目录", /(展开|全部|所有|显示|查看|更多).*(章节|目录)/m];

// [下一页]元素的匹配符号
const MATCHING_SYMBOLS_FOR_NEXT_PAGE = [/下(一|1)(页|目录|面)/];

// [章节名称]的匹配符号
const MATCHING_SYMBOLS_FOR_CHAPTER = [/(第|)[0-9]+(章|节)/, /(第|)[零一二三四五六七八九十百千万亿]+(章|节)/];


// 是否格式化章节名称
const IS_FORMAT = false;

/**
 * 格式化章节名称
 * 将章节名称中的中文数字转换为阿拉伯数字，并去除空格
 * @param {String} name 章节名称
 * @returns {String}
 */
function formatChapterName(name) {
    // 中文数字转阿拉伯数字的函数
    function chineseToNumber(chnStr) {
        let chnNumChar = {
            零: 0,
            一: 1,
            二: 2,
            两: 2,
            三: 3,
            四: 4,
            五: 5,
            六: 6,
            七: 7,
            八: 8,
            九: 9
        };
        let chnNameValue = {
            十: { value: 10, secUnit: false },
            百: { value: 100, secUnit: false },
            千: { value: 1000, secUnit: false },
            万: { value: 10000, secUnit: true },
            亿: { value: 100000000, secUnit: true }
        }
        let rtn = 0;
        let section = 0;
        let number = 0;
        let secUnit = false;
        console.log(chnStr);
        let str = chnStr.split('');

        for (let i = 0; i < str.length; i++) {
            let num = chnNumChar[str[i]];
            if (typeof num !== 'undefined') {
                number = num;
                if (i === str.length - 1) {
                    section += number;
                }
            } else {
                let unit = chnNameValue[str[i]].value;
                secUnit = chnNameValue[str[i]].secUnit;
                if (secUnit) {
                    section = (section + number) * unit;
                    rtn += section;
                    section = 0;
                } else {
                    section += (number * unit);
                }
                number = 0;
            }
        }
        return rtn + section;
    }

    const chapterNumber = name.match(/[零一二三四五六七八九十百千万亿]+(章|节)/)[0];
    if (chapterNumber === null) return name.trim();

    const arabicNumber = chineseToNumber(chapterNumber);
    return name.replace(chapterNumber, arabicNumber).trim();
}

/**
 * 查找内容是否包含数组中的内容
 * @param {String} content 需要查找的内容
 * @param {Array} arr 包含字符串或正则表达式
 * @returns {Boolean}
 */
function findByArr(content, arr) {
    for (let i = 0; i < arr.length; i++) {
        if (arr[i] instanceof RegExp) {
            if (arr[i].test(content)) return true;
        } else {
            if (content.includes(arr[i])) return true;
        }
    }
    return false;
}

/**
 * 获取本页所有章节的名称和链接
 * @param {Document} _document  需要获取章节的document
 * @param {Boolean} isFormat 是否格式化章节名称
 * @returns {Array<Map>}
 */
function getChapters(_document, isFormat) {
    let chapters = {};
    _document.querySelectorAll('a')
        .forEach(element => {
            if (element.textContent && element.href && findByArr(element.textContent, MATCHING_SYMBOLS_FOR_CHAPTER)) {
                const name = isFormat ? formatChapterName(element.textContent) : element.textContent;
                chapters[name] = chapters[name] || [];
                chapters[name].push(element.href);
            }
        });
    return chapters;
}


/**
 * 寻找网页中可以点击且匹配指定符号的元素
 * @param {Document} _document 需要查找元素的document
 * @param {Array} arr 包含字符串或正则表达式
 * @returns {HTMLElement}
 */
function findElement(_document, arr) {
    let element;
    _document.querySelectorAll('a, button, input[type="button"], input[type="submit"]')
        .forEach(_element => {
            if (findByArr(_element.textContent, arr) && _element.offsetParent !== null) {
                element = _element
                return;
            }
        });
    return element;
}

// 寻找展开是否有展开所有章节的元素
const expandElement = findElement(document, MATCHING_SYMBOLS_FOR_EXPANDING);
if (expandElement) {
    expandElement.click();
}
// 等待5s防止刷新未完成
await new Promise(resolve => setTimeout(resolve, 5000));

// 检查是否有下一页的元素
let nextElement = findElement(document, MATCHING_SYMBOLS_FOR_NEXT_PAGE);

// 先获取本页的章节
let chapters = getChapters(document, IS_FORMAT);


// 循环获取下一页的章节
// 创建iframe
const frame = document.createElement('iframe');
frame.width = 1000;
frame.height = 500;
document.body.appendChild(frame);

while (nextElement && nextElement.offsetParent !== null && !nextElement.disabled) {
    frame.contentWindow.location.href = nextElement.href;
    // 等待frame加载完成
    await new Promise(resolve => frame.addEventListener('load', resolve));
    // 获取此页的章节
    const _document = frame.contentDocument;
    chapters = Object.assign(chapters, getChapters(_document, IS_FORMAT));
    // 获取下一页的元素
    const _nextElement = findElement(_document, MATCHING_SYMBOLS_FOR_NEXT_PAGE);
    if (_nextElement.href === nextElement.href) break;
    nextElement = _nextElement;
}

let finallyChapters = {};

let i = 0;
for (const chapter in chapters) {
    console.log(chapter, chapters[chapter]);
    finallyChapters[`${++i}`] = {
        name: chapter,
        url: chapters[chapter]
    }
}

console.log(finallyChapters);
return finallyChapters;