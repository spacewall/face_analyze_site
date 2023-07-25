import os
import streamlit as st
from streamlit_echarts import st_echarts
from camera_input_live import camera_input_live
from deepface import DeepFace
from PIL import Image

def update_and_save_img(img_file_buffer) -> None:
    if "img.jpg" in os.listdir():
        os.remove("img.jpg")
    
    try:
        img = Image.open(img_file_buffer)
        img.save("img.jpg")
    except AttributeError as error:
        return error

def face_analyze(camera_handler):
    try:
        return DeepFace.analyze(camera_handler, ('emotion', 'age', 'gender', 'race'))
    except ValueError:
        return None

def draw_pie(data):
    options = {
        "tooltip": {"trigger": "item"},
        "legend": {"top": "5%", "left": "center"},
        "series": [
            {
                "name": "pie",
                "type": "pie",
                "radius": ["40%", "70%"],
                "avoidLabelOverlap": False,
                "itemStyle": {
                    "borderRadius": 10,
                    "borderColor": "#fff",
                    "borderWidth": 2,
                },
                "label": {"show": False, "position": "center"},
                "emphasis": {
                    "label": {"show": True, "fontSize": "40", "fontWeight": "bold"}
                },
                "labelLine": {"show": False},
                "data": [],
            }
        ],
    }

    options["series"][0]["data"] += data

    st_echarts(
        options=options, height="450px",
    )

st.title("Deep Face Analyze Technology", anchor=False)
st.divider()
col_1, col_2 = st.columns(2)
with col_1:
    st.subheader(":blue[О приложении]")
    st.write("Приложение определяет пол, возраст, национальную принадлежность, а также эмоцию по фотографии пользователя.")

with col_2:
    st.subheader(":blue[Как сохранить результат?]")
    st.write("В правом верхнем углу выберете пункт 'Print', чтобы распечатать страницу, или воспользуйтесь сочетанием 'ctrl + s', чтобы сохранить страницу.")

st.divider()
img_file_buffer = camera_input_live(":blue[Нажмите на кнопку, чтобы снять фото]")

col_3, col_4 = st.columns(2)

if img_file_buffer is not None:
    update_and_save_img(img_file_buffer)
    
    try:
        with st.spinner('Обработка изображения…'):
            result = face_analyze("img.jpg")

            data = result[0]

            emotions = list()
            for key, value in data.get("emotion").items():
                emotions.append({"value": round(value, 2), "name": key})

            races = list()
            for key, value in data.get("race").items():
                races.append({"value": round(value, 2), "name": key})

        with col_3:
            st.subheader(":blue[Races]")
            draw_pie(races)
            st.caption(f"Dominant race: {data.get('dominant_race')}")

            st.subheader(":blue[Age]")
            st.write(f"Your age is {data.get('age')}")

        with col_4:
            st.subheader(":blue[Emotions]")
            draw_pie(emotions)
            st.caption(f"Dominant emotion: {data.get('dominant_emotion')}.")

            st.subheader(":blue[Gender]")
            st.write(f"Your gender is {data.get('dominant_gender')}.")
    except TypeError:
        st.warning("Лицо не найдено, попробуйте другой ракурс!", icon="🚨")      
