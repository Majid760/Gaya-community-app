

/// AGE limit
const AGE_LIMITS = [13, 14, 15, 16, 17, 18, 19]

//// All Genders
const DEFAULT_USER_AVATAR = "https://firebasestorage.googleapis.com/v0/b/gaya-5876c.appspot.com/o/assets%2Fuser-default.png?alt=media&token=4a1481bb-fcbc-40c0-81ed-f583674ab6a7";
const FEMALE_AVATARS = [
    "https://i.quotev.com/jymuvvneaaaa.jpg",
    "https://p.favim.com/orig/2019/01/26/tumblr-girl-tumblr-Favim.com-6805020.jpg",
    "https://64.media.tumblr.com/f246e49c023bf08b175bc658c649b373/2887b35bfa0d5ca5-50/s400x600/397f8e54e3532421f456e34b59ea2c5757c4ad9d.png",
    "https://i.pinimg.com/736x/83/49/52/83495251a1fcfcca67777f7bb32cd214.jpg",
    "https://i.pinimg.com/236x/56/ed/ee/56edee46de010b45ee0a1ac71feca7ad.jpg",
]
const MALE_AVATARS = [
    'https://i.pinimg.com/236x/5a/3c/ae/5a3caebede4f3a09fc9ba6ebf8e91100--christian-collins-tumblr-boys.jpg',
    'https://78.media.tumblr.com/7319f245b896992b83c563fad84f7f9a/tumblr_pk8z2q4Llh1w6t9qa_540.jpg',
    'https://64.media.tumblr.com/ecaf6ac9680f5a2e8689c3b3e31e9275/tumblr_pedt1w7bay1s2cpc1_1280.pnj',
    "https://i.pinimg.com/736x/8a/19/3d/8a193deb10b46bc465ed8a1d05e0eb76--hot-teens-cute-boys.jpg",
    'https://live.staticflickr.com/3773/11466235995_8190160744_n.jpg',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRgvYpagso4fGCjJWoHG65Gv5LaStutJ_-rSg&usqp=CAU'
]
const NB_AVATARS = [
    "https://i.pinimg.com/736x/82/57/0f/82570fd31c0e71dc0a9b3ffd13cfe4e7.jpg",
    "https://static.boredpanda.com/blog/wp-content/uuuploads/cute-baby-animals/cute-baby-animals-2.jpg",
    "https://i.pinimg.com/originals/dd/5b/01/dd5b01f0219c5d6afa30f954852f2e00.png",
    "https://cdn1.tedsby.com/tb/medium/storage/4/2/8/428976/teddy-bear-baby-panda-by-sofya-potapenko.jpg",
    "https://i.pinimg.com/originals/65/ac/b8/65acb89e92af272191efdaff8da0aa03.jpg"
];

/// All Abouts
const ABOUTS = [
    'אוהבת טכנולוגיה ומתרגשת מהפתעות טכנולוגיות 📱✨',
    'מגלה יופי בפרטים הקטנים של החיים 🌸🔍',
    'חובבת מוזיקה ומתרגשת מקולות עוצמתיים 🎶🎤',
    'מתרגשת מהפתעות חיי היומיום ומפגישות חדשות 🌟😄',
    'חובבת אומנות ואוהבת ליצור ביצירות עצמיות 🎨✨',
    'אוהבת טבע ומתרגשת מאפשרויות טיול והרפתקאות 🌿🌄',
    'משתתפת בפרוייקטים חברתיים וקהילתיים מרתקים 💪🌍',
    'אוהבת לחקור תרבויות חדשות ולהתנסות במטבח 🌍🍽️',
    'חובבת את הטבע והפרחים המרהיבים 🌺🌼',
    'מתרגשת לטפס ולכבוש שיאים מסעירים 🧗‍♀️🏔️',
    'מאמינה שהחיים הם מסע מרתק וצבעוני 🌈✨',
    'חובבת את המוסיקה ולהתרגש מהופעות חיות 🎵🎤',
    'אוהבת ליצור ולתכנת אפליקציות מובייל 📱💻',
    'מתרגשת ללמוד שפות חדשות ולהכיר תרבויות שונות 🌍🗺️',
    'אוהבת לצלם את השקט המרתק של הים בשעות הבוקר 🌅📸',
    'חובבת פילאטיס ולחיות חיים בריאים ואיכותיים 💪🌿',
    'מתרגשת להפיק סרטונים מקוצרים ולערוך אותם 🎬✂️',
    'אוהבת לשדרג תמונות וליצור עיצובים מרהיבים 🌈📸',
    'מתרגשת ללמוד כלי נגינה חדשים ולנגן יצירות מופת 🎵🎻',
    'חובבת פרפורמנסים ולהופיע לקהל המופתע 🎭🌟',
    'מתרגשת להביא את האמנות לכל פינה בחיי היומיום 🎨✨',
    'אוהבת לבשל מתכונים מרתקים ומקוריים 🍳🌶️',
    'חובבת עיצוב האופנה ולשלב פריטים ייחודיים 👗✨',
    'מתרגשת למצוא מסעות ברחבי העולם ולחוות חוויות מרהיבות 🌍🌟',
    'אוהבת ליצור מראה ייחודי בעיצוב הבית 🏠✨',
    'מתרגשת להתמקצע וללמוד דברים חדשים כל יום 📚🌟',
    'חובבת טיולים רגליים ולגלות פארקים טבעיים חדשים 🏞️🌳',
    'אוהבת לטפס ולכבוש פינות גבוהות בים הגדול 🏄‍♀️🌊',
    'מתרגשת לחקור ולגלות מסעות בעולם התת-ימי 🐠,🐙,🐬',
    'חובבת טכנולוגיה ובעלת מוח מחושב וחקרן 🖥️💡',
    'אוהבת למצוא יופי בדברים פשוטים ולהקפיץ רגעים קטנים 🌼😄',
    'מקפיצה לחוויות חדשות ואוהבת ללמוד דברים חדשים 🌟📚',
    'אוהבת לטייל בטבע ולהתרגש מפגישות עם חיות בר 🌿🐾',
    'חובבת מוזיקה ומתרגשת מסאונדים אותנטיים ומרגשים 🎵🎶',
    'מתעניינת באירועים ומאהבת לצרוב זיכרונות בתמונות 📷🌟',
    'אוהבת לחקור תרבויות ולהתנסות באוכל מסורתי מסביב לעולם 🌍🍽️',
    'מתרגשת מהתקדמות טכנולוגית ומחקר על המזרח הרחוק 🌐⚙️',
    'אוהבת לסייר בחופים ולקחת חלק באירועים מרתקים 🏖️🌊',
    'מחפשת את השפע בחיי היומיום ומחקר דרכים חדשות 🌟🔍',
    'אוהבת ללמוד על תרבויות שונות ולהכיר אנשים מרחבי העולם 🌍🤝',
    'חובבת אימון ומתרגשת מהשיפור האישי והפיתוח המקצועי 💪📈',
    'אוהבת למצוא את היצירתיות בכל דבר ולהביע את הדמיון 🎨✨',
    'מפגשים עם אנשים חדשים והתרגשות מחוויות שונות 🤝🌟',
    'אוהבת לקרוא ספרים ולהתעמק בעולמם המורכב 📚🔍',
    'חובבת ספורט ומחפשת את האתגרים הגופניים והמנטאליים 💪🏋️',
    'אוהבת להקשיב למוזיקה ולחוות את הרגע בכל רגע 🎶🌟',
    'מתרגשת מהתקדמות טכנולוגית ומחקר חדשנות בתחום 💡🔬',
    'אוהבת להתנסות במטבח וליצור מנות חדשות ומרתקות 🍳🔪',
    'חובבת הקרבות והטיולים בארץ ובעולם, לחופש והרפתקאות 🌍✈️',
    'מתרגשת מפגישות מעניינות עם אנשים ומחוויות חדשות 🤝🌟',
    'אוהבת לתכנן ולארגן אירועים מותאמים אישית ומיוחדים 🎉🎊',
    'מתרגשת ממסעות בעולם וחוויות מתחדשות בכל פעם 🌎✈️',
    'אוהבת לטעום את העולם דרך האוכל ולגלות טעמים חדשים 🍽️🌟', 'חובבת ספורט ומתרגשת משיפור היכולת הגופנית והנפשית 💪🌟',
]


/// ALL INTEREST TOPICS
const INTEREST_TOPICS = [
    { 'title': 'Self development', 'image': '🎯' },
    { 'title': 'Funny', 'image': '😂' },
    { 'title': 'School', 'image': '📚' },
    { 'title': 'Friends', 'image': '👫' },
    { 'title': 'Gaming', 'image': '🎮' },
    { 'title': 'Relationships', 'image': '💋' },
    { 'title': 'Art', 'image': '🎨' },
    { 'title': 'Health', 'image': '🌿' },
    { 'title': 'Food', 'image': '🍔' },
    { 'title': 'Beauty', 'image': '💅🏻' },
    { 'title': 'Life style', 'image': '💫' },
    { 'title': 'Fitness', 'image': '🏃🏽‍♀' },
    { 'title': 'Inspiration', 'image': '💡' },
    { 'title': 'DIY', 'image': '🖌' },
    { 'title': 'Advice', 'image': '🙏🏻' },
    { 'title': 'Writing', 'image': '📝' },
    { 'title': 'Love', 'image': '❤️' },
    { 'title': 'Movies', 'image': '🎥' },
    { 'title': 'Animals', 'image': '🐶' },
    { 'title': 'Fashion', 'image': '👗' },
    { 'title': 'Sports', 'image': '⚽' },
    { 'title': 'Girls talk', 'image': '💁‍♀' },
    { 'title': 'TV', 'image': '📺' },
    { 'title': 'Travel', 'image': '✈️' },
    { 'title': 'Confessions', 'image': '🤫' },
    { 'title': 'Entrepreneurship', 'image': '💡' },
    { 'title': 'Anime', 'image': '🎎' },
    { 'title': 'Music', 'image': '🎵' },
    { 'title': 'Dance', 'image': '👯‍♀️' },
    { 'title': 'Poems', 'image': '📖' },
    { 'title': 'Photography', 'image': '📷' },
    { 'title': 'Books', 'image': '📚' },
    { 'title': 'Parties', 'image': '🎉' },
    { 'title': 'Motorsport', 'image': '🚗' },
    { 'title': 'Metal', 'image': '🤘' },
    { 'title': 'K pop', 'image': '🎼' },
    { 'title': 'Crypto', 'image': '🔐' },
    { 'title': 'Design', 'image': '👩‍🎨' },
    { 'title': 'Content creation', 'image': '🤔' },
    { 'title': 'Cars', 'image': '🚘' },
    { 'title': 'Marvel Nintendo DC', 'image': '🤩' },
    { 'title': 'Blog', 'image': '💻' },
    { 'title': 'Horse racing', 'image': '🐎' },
    { 'title': 'Business', 'image': '📈' },
    { 'title': 'Money', 'image': '💰' },
    { 'title': 'Science', 'image': '🧬' },
    { 'title': 'Hobbies', 'image': '🧸' },
    { 'title': 'Technology', 'image': '👩‍💻' },
    { 'title': 'Celebrity', 'image': '📸' },
    { 'title': 'Space', 'image': '🪐' },
    { 'title': 'Leadership', 'image': '🔑' },
    { 'title': 'Board games', 'image': '🎁' },
    { 'title': 'Cooking', 'image': '🥣' },
    { 'title': 'Programming', 'image': '🖥️' },
    { 'title': 'Basketball', 'image': '🏀' },
    { 'title': 'Football', 'image': '⚽️' },
    { 'title': 'Tennis', 'image': '🎾' },
    { 'title': 'Cyber', 'image': '🤖' },
    { 'title': 'Nonsense', 'image': '👀' },
    { 'title': 'Criminology', 'image': '👣' },
    { 'title': 'Dating', 'image': '👩‍❤️‍👨' },
    { 'title': 'LGBTQ+', 'image': '🏳️‍🌈' },
    { 'title': 'Knitting', 'image': '🧶' },
    { 'title': 'News', 'image': '📰' }
]

/// All Names
const MALE_FIRSTNAME = [
    'Noam',
    'Itai',
    'Amit',
    'Omer',
    'Yoni',
    'Eitan',
    'Barak',
    'Tomer',
    'Matan',
    'Ariel',
]
const MALE_LASTNAME = [
    'Cohen',
    'Levi',
    'BenDavid',
    'Amar',
    'Mizrahi',
    'Azoulay',
    'Bitton',
    'Cohen',
    'Barak',
    'Avraham',
]

const FEMALE_FIRSTNAME = [
    'Maya',
    'Yael',
    'Adi',
    'Noa',
    'Tamar',
    'Liora',
    'Shira',
    'Michal',
    'Neta',
    'Roni',
]
const FEMALE_LASTNAME = [
    'Cohen',
    'Levi',
    'BenDavid',
    'Amar',
    'Mizrahi',
    'Azoulay',
    'Bitton',
    'Cohen',
    'Barak',
    'Avraham',
]








module.exports = {
    DEFAULT_USER_AVATAR,
    FEMALE_AVATARS,
    MALE_AVATARS,
    NB_AVATARS,
    ABOUTS,
    INTEREST_TOPICS,
    MALE_FIRSTNAME,
    MALE_LASTNAME,
    FEMALE_FIRSTNAME,
    FEMALE_LASTNAME,
    AGE_LIMITS,
}