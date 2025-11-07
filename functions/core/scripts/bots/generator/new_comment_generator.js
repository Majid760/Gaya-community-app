
const comments = [
    'I like this post',
    'This post is awesome',
    'This post is great',
    'This post is amazing',
    'This post is cool',
    'This post is nice',
    'This post is good', 
]


const randomComment = () => {
    const randomIndex = Math.floor(Math.random() * comments.length)
    return comments[randomIndex]
}

module.exports =  randomComment
