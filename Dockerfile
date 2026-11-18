FROM python:3.9


# Cコンパイラをインストールし、キャッシュを削除してイメージサイズを削減
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -r uwsgi && useradd -r -g uwsgi uwsgi
RUN pip install Flask==0.10.1  uWSGI==2.0.21 JInja2==2.11.3 Werkzeug==0.16.1 itsdangerous==1.1.0 markupsafe==1.1.1 requests==2.5.1 redis==2.10.3
WORKDIR /app
COPY app /app
COPY cmd.sh /


EXPOSE 9090 9191
USER uwsgi

CMD ["/cmd.sh"]

