from face_analyze import update_and_save_img

def test_update():
    fake_img_file_buffer = tuple([1, 2, 3])
    assert update_and_save_img(fake_img_file_buffer) != None
