# civil-law-exam-prep-app

A small mock exam app to help the preparation for a Civil Law exam. The original question sheet is curated by the students of the faculty organizing the exam. I don't have any domain knowledge in civil law, the app is made to help the preparation of someone else, so no guarantees for the correctness of the answers.

My first attempt in writing an application using Flutter.

The app looks something like this:
<p align="center">
<img src="https://github.com/nagybalint/civil-law-exam-prep-app/assets/6596250/d7b47d03-a4ec-4cc7-bb09-7d3028fba577" width="300"/>
</p>

The project consist of the following parts:
- The Flutter application for doing the mock exam under `app/polgarjog_kikerdezo`
- The raw sheet of questions and answers, curated by the students of the law faculty, under `raw_resources` in a couple of formats
- A small python utility to get a well-formatted list of the questions and answers based on the raw resources, under `parsed_questions`

As we have a static and immutable list of questions and answers and the app will only be used for a couple of weeks and then deleted, a lot of corners have been cut during the development
- I'm sure styling and state management can be done in a much cleaner way
- No tests have been added
- As the questions are about Hungarian law, in Hungarian, the app is not internationalized and can display Hungarian text only. The code however is made so that it can be read by international audiences as well
- Manually tested, and only on iPhones
