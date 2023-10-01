from bs4 import BeautifulSoup
import json

def mark_correct_answer(nr, a_nr):
    indexed_questions[nr]['a'][a_nr].attrs['class'].append('c3')

def merge_qs(q1, q2):
    indexed_questions[q1]["q"].contents.append(indexed_questions[q2]["q"].contents[0])
    indexed_questions[q1]["a"] = indexed_questions[q2]["a"]
    del indexed_questions[q2]

def merge_as(q, a1, a2, is_good: False):
    indexed_questions[q]["a"][a1].contents.append(indexed_questions[q]["a"][a2].contents[0])
    del indexed_questions[q]["a"][a2]
    if(is_good):
        indexed_questions[q]["a"][a1].attrs['class'] = ["c3"]
    else:
        indexed_questions[q]["a"][a1].attrs['class'] = ["c4"]

# Read questions from source and do initial cleanup
with open("../raw_resources/original_questions.html", "r") as file:
    qs = file.read()

soup = BeautifulSoup(qs, "html.parser")
all_spans = soup.find_all("span")[42:]
non_empty_spans = [s for s in all_spans if len(s.contents) > 0 and str.strip(s.contents[0]) != ""]
non_abcd = [s for s in non_empty_spans if str.strip(s.contents[0]) not in ["A)", "B}", "C)", "D)"]]
h1 = [a for a in non_abcd if "class" in list(a.attrs) and "c38" in a.attrs['class'] and a.parent.name == "h1"]
for h in h1:
    non_abcd.remove(h)
qs_dict = []
for elem in non_abcd:
    try:
        classes = elem.attrs["class"]
        if("c1" in classes):
            qs_dict.append({"q": elem, "a": []})
        else:
            qs_dict[-1]["a"].append(elem)
    except:
        qs_dict[-1]["a"].append(elem) 
indexed_questions = { i:orig for (i, orig) in enumerate(qs_dict) }

# Correcting questions that failed to parse fully automatically
merge_qs(3, 4)
merge_as(15, 1, 2, True)
merge_qs(33, 34)
merge_as(45, 2, 3, True)
merge_qs(46, 47)
merge_as(54, 1, 2, False)
merge_qs(70, 71)
merge_as(70, 0, 1, False)
merge_qs(92, 93)
merge_qs(95, 96)
merge_qs(95, 97)
merge_qs(95, 98)
merge_as(113, 0, 1, True)
merge_as(115, 1, 2, True)
del indexed_questions[116]
merge_as(133, 2, 3, False)
merge_qs(145, 146)
merge_qs(155, 156)
merge_as(159, 3, 4, False)
merge_as(166, 5, 6, False)
merge_as(166, 3, 4, False)
merge_as(166, 1, 2, True)
merge_as(182, 1, 2, False)
merge_as(186, 1, 2, True)
merge_qs(192, 193)
merge_as(197, 1, 2, True)
merge_as(211, 0, 1, False)
merge_as(271, 2, 3, True)
merge_as(292, 2, 3, True) # Duplicate of 271
merge_as(303, 2, 3, True)
merge_as(314, 1, 2, True)
merge_as(315, 1, 2, True)
merge_as(328, 3, 4, True)
merge_as(329, 0, 1, True)
merge_as(337, 3, 4, False)
merge_as(420, 2, 3, False)
merge_as(484, 0, 1, True)
merge_as(485, 0, 1, True)
merge_as(490, 0, 1, True)
merge_qs(284, 285)
del indexed_questions[289]
merge_qs(331, 332)
merge_qs(377, 378)
merge_qs(379, 380)
merge_qs(425, 426)
merge_qs(471, 472)
merge_qs(497, 498)
merge_qs(499, 500)
merge_as(478, 4, 5, True)
merge_as(478, 1, 2, False)

indexed_questions[409]["a"][0].contents[0] = "í" + indexed_questions[409]["a"][0].contents[0]
indexed_questions[408]["a"] += indexed_questions[409]["a"]
del indexed_questions[409]
del indexed_questions[238]
del indexed_questions[239]

# Removing crossed out questions
crossed_out_questions = {}
for k, q in indexed_questions.items():
    try:
        if 'c9' in q['q'].attrs['class']:
            crossed_out_questions[k] = q
    except:
        pass

for k in crossed_out_questions.keys():
    del indexed_questions[k]

# Filter and correct answers
mark_correct_answer(185, 1)

questions_without_single_correct_answer = {}
for k, q in indexed_questions.items():
    q['correct_answers'] = []
    for i, a in enumerate(q['a']):
        try: 
            if 'c3' in a.attrs['class'] or 'c23' in a.attrs['class']:
                q["correct_answers"].append(i)
        except:
            pass
    if len(q["correct_answers"]) != 1:
        questions_without_single_correct_answer[k] = q

for k in questions_without_single_correct_answer.keys():
    del indexed_questions[k]

# Create well formatted list of questions
questions = []
for q in indexed_questions.values():
    questions.append({
        "question": " ".join(q["q"].contents),
        "answers": [" ".join(a.contents) for a in q["a"]],
        "correct": q["correct_answers"][0]
    })

with open("questions.json", "w") as jsonfile:
    content = json.dumps(questions, ensure_ascii=False, indent=2)
    jsonfile.write(content)
