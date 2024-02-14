FROM python:3.12.1-bullseye

WORKDIR /usr/src/app
#
RUN apt-get update && \
    apt-get install -y locales && \
    sed -i -e 's/# es_MX.UTF-8 UTF-8/es_MX.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales

ENV LANG es_MX.UTF-8
ENV LC_ALL es_MX.UTF-8

COPY python/config/requeriments.txt ./
RUN pip install --no-cache-dir -r requeriments.txt

COPY . .

#ENTRYPOINT ["/bin/bash", "-c", "python3 __main__template.py && python3 __main__downloader.py '/home/data/templates' '/home/data/dicoms'"]

ENTRYPOINT ["/bin/bash", "-c", "python3 __main__template.py && python3 __main__interpretation.py '/home/data/templates' '/home/data/interpretations'"]

#ENTRYPOINT ["/bin/bash", "-c", "python3 finder_sitdris.py 'Concentrado.xlsx'"]

#CMD ["/bin/bash", "-c", "chmod +x init.sh && sh init.sh"]
