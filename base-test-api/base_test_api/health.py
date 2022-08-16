from flask import Blueprint

health_bp = Blueprint('health', __name__)


@health_bp.route('/ping', methods=['GET'])
def ping():
    return "pong"
