// Description: 获取文章内容


/**
 * 获取元素的XPath
 * @param {HTMLElement} element
 * @returns {String}
 */
function getElementXPath(element) {
    if (element.id !== "") { // 如果元素具有 ID 属性
        return '//*[@id="' + element.id + '"]'; // 返回格式为 '//*[@id="elementId"]' 的 XPath 路径
    }
    if (element === document.body) { // 如果当前元素是 document.body
        return "/html/body"; // 返回 '/html/body' 的 XPath 路径
    }

    var index = 1;
    const childNodes = element.parentNode ? element.parentNode.childNodes : []; // 获取当前元素的父节点的子节点列表
    var siblings = childNodes;

    for (var i = 0; i < siblings.length; i++) {
        var sibling = siblings[i];
        if (sibling === element) { // 遍历到当前元素
            // 递归调用，获取父节点的 XPath 路径，然后拼接当前元素的标签名和索引
            return (
                getElementXPath(element.parentNode) +
                "/" +
                element.tagName.toLowerCase() +
                "[" +
                index +
                "]"
            );
        }
        if (sibling.nodeType === 1 && sibling.tagName === element.tagName) { // 遍历到具有相同标签名的元素
            index++; // 增加索引值
        }
    }
}

// 获取网页内所有有文字的元素
const elementsWithText = Array.from(document.querySelectorAll('*')).filter(element => {
    // // 排除html和body和script和style标签
    if (['HTML', 'BODY', 'SCRIPT', 'STYLE'].includes(element.tagName)) return false;

    // // 如果元素的子元素有文字，则不获取
    // if (element.querySelector('*')) return false;
    // 如果被隐藏了，则不获取
    if (element.offsetParent === null) return false;
    console.log(element.innerText)
    return element?.innerText?.trim()?.length > 0;
});

// 获取所有有文字的元素的父元素的XPath
const textElementsParentElements = elementsWithText.map(element => {
    console.log(getElementXPath(element.parentElement), element.innerText)
    return {
        text: element.innerText,
        parentXPath: getElementXPath(element.parentElement)
    };
});

// 根据父元素的XPath进行分类
const textElementsParentElementsMap = {};
textElementsParentElements.forEach(element => {
    textElementsParentElementsMap[element.parentXPath] = textElementsParentElementsMap[element.parentXPath] || [];
    textElementsParentElementsMap[element.parentXPath].push(element.text);
});

// 获取最多的父元素的XPath
let maxParentXPath = "";
let maxParentXPathTextLength = 0;
for (const parentXPath in textElementsParentElementsMap) {
    const textLength = textElementsParentElementsMap[parentXPath].join('').length;
    if (textLength > maxParentXPathTextLength) {
        maxParentXPath = parentXPath;
        maxParentXPathTextLength = textLength;
    }
}

// 获取最多字数的文章

// 最多字数的文章
let articleMaxTextLength = "";
let maxTextLength = 0;
textElementsParentElementsMap[maxParentXPath].forEach(text => {
    if (text.length > maxTextLength) {
        articleMaxTextLength = text;
        maxTextLength = text.length;
    }
});


// 整合数据

// 最多相同父元素的文章
const articleMaxSameParent = textElementsParentElementsMap[maxParentXPath].join('\n');

// 最多字数的文章
const article = articleMaxSameParent >= articleMaxTextLength ? articleMaxSameParent : articleMaxTextLength;

console.log(article);

return { article };