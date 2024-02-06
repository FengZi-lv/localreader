// Description: 获取图书信息

// 网页标题中需要去除的符号，去除后的标题将作为图书名称
const MATCHING_SYMBOLS_FOR_BOOK_NAME = [/.*《/, /》.*/, /([\u4e00-\u9fa5]| |_|\-|)+(最新章节|(全文|全文免费)阅读|无弹窗|无广告|笔趣阁|手机版|电脑版)/, /(\(|（).+(\)|）)/];

// 图书作者的符号, namedgroup: `author`
const MATCHING_SYMBOLS_FOR_BOOK_AUTHOR = [/(作者|作家)(:|：|)(?<author>.+)/];


// 获取网页标题
let bookName = document.title;
for (const symbol of MATCHING_SYMBOLS_FOR_BOOK_NAME) {
    bookName = bookName.replace(symbol, '');
}

// 获取body的所有文字
const bodyText = document.body.innerText;
let bookAuthor = '';
for (const symbol of MATCHING_SYMBOLS_FOR_BOOK_AUTHOR) {
    const match = bodyText.match(symbol);
    if (match) {
        bookAuthor = match.groups.author;
        break;
    }
}

// 获取网页内所有有图片的元素
const elementsWithImage = Array.from(document.querySelectorAll('img')).filter(element => {
    // 如果被隐藏了，则不获取
    if (element.offsetParent === null) return false;
    return true;
});

// 获取所有有图片的元素的链接
const imageElementsSrc = elementsWithImage.map(element => {
    return element.src;
}).filter(src => !(src.endsWith('.svg') || src.endsWith('.gif')));

// 整合数据
const bookInfo = {
    bookName,
    bookAuthor,
    'bookMainURL': document.URL,
    'bookCover': imageElementsSrc,
};

console.log(bookInfo);
return bookInfo;