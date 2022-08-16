import os

from flask_script import Manager, Server

from base_test_api.app import app

manager = Manager(app)
server = Server(host="0.0.0.0", port=os.getenv('PORT', 8080))
manager.add_command("runserver", server)

if __name__ == "__main__":
    manager.run()
