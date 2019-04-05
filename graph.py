#!/usr/bin/python3
from github import Github
from PIL import Image, ImageDraw
import sys

github = Github("7bcb5eb3175e7ba8649274b65be1b3e23b5b3fdd")
github_org = github.get_organization('stuvusIT')

activity_stream = [[0]*7 for i in range(52)]
activity_avrage = 0

month_names = ['Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember']
month_list = [None] * 52

for repo in github_org.get_repos():
    activity_stream_repo = repo.get_stats_commit_activity()
    print(repo.name)
    try:
        for i_week in range(len(activity_stream_repo)):
            for i_day in range(7):
                activity_stream[i_week][i_day] += activity_stream_repo[i_week].days[i_day]
                activity_avrage += activity_stream_repo[i_week].days[i_day]
            month_name = month_names[activity_stream_repo[i_week].week.month-1]
            if month_name not in month_list and \
                    ( month_name != month_names[activity_stream_repo[51].week.month-1] or i_week > 25):
                month_list[i_week] = month_name
    except TypeError:
        print('repo is strange', repo.name, repo, activity_stream_repo)

activity_avrage /= 7*52
activity_avrage = round(activity_avrage*2)

#activity_img = Image.new('RGBA', (726, 96))
activity_img = Image.new('RGBA', (800, 110))
activity_draw = ImageDraw.Draw(activity_img)

def get_color(activity):
    color_factor = 255/activity_avrage
    alpha = color_factor * activity
    if alpha > 255:
        alpha = 255
        sys.stdout.write('.')
    return (0, 100, 0, int(alpha))

for x in range(52):
    for y in range(7):
        activity_draw.rectangle(
                [11*x+3*x, 11*y+3*y, 11*x+3*x+11, 11*y+3*y+11],
                outline=(125,125,125,255),
                fill=get_color(activity_stream[x][y])
                )
    if month_list[x]:
        activity_draw.text([11*x+3*x+4, 11*6+3*6+11+2], month_list[x], fill=(0,0,0,255))

weekdays = ['Sonntag', 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag']
for y in range(7):
    print(y)
    activity_draw.text([11*51+3*51+11+4, 11*y+3*y], weekdays[y], fill=(0,0,0,255))

activity_img.save('test.png')
print(activity_avrage)
print(month_list)
