from face_analyze import update_and_save_img, face_analyze

def test_update():
    fake_img_file_buffer = tuple([1, 2, 3])
    assert update_and_save_img(fake_img_file_buffer) != None

def test_face_analyze():
    assert face_analyze('cat.jpg') == None
