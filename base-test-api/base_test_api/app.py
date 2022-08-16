import os

from flask import Flask

def create_app():
    app_base_test_api = Flask(__name__)

    config_env = os.environ.get('BASE_TEST_ENV', '').title()
    app_base_test_api.config.from_object('base_test_api.config.{}Config'.format(config_env))

    return app_base_test_api


app = create_app()


def register_blueprints():
    from base_test_api.health import health_bp

    app.register_blueprint(health_bp, url_prefix='/api')


register_blueprints()
