# Analyze yourself app

## Как пользоваться?

---

### Самостоятельно для Linux и MacOS

- <code>git clone https://gitlab.s.rosatom.education/user08/analyze_yourself</code>
- <code>python3 -m venv venv</code>
- <code>source /venv/bin/activate</code>
- <code>pip install -r requirements.txt</code>

---

### При помощи Docker

**MacOS**
<code>docker compose up --build</code>

**Linux**
<code>docker-compose up</code>

---

## Особенности работы

Для корректного выполнения функций библиотеки DeepFace необходимы дополнительные зависимости (модели), которые автоматически подгружаются библиотекой при вызове функции. Однако в данном контейнере зависимости подгружаются заранее в соответствующую папку /.deepface/weights.
