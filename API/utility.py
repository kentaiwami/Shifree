import datetime


def get_salary(user, shift):
    if user.daytime_start is None or user.daytime_end is None or user.daytime_wage is None or user.daytime_wage == 0 or\
        user.night_start is None or user.night_end is None or user.night_wage is None or user.night_wage == 0 or \
        shift.start is None or shift.end is None:
        return 0

    year = datetime.datetime.now().year
    month = datetime.datetime.now().month
    day = datetime.datetime.now().day

    user_daytime_start = datetime.datetime(year=year, month=month, day=day, hour=user.daytime_start.hour,
                                           minute=user.daytime_start.minute)
    user_daytime_end = user_daytime_start
    user_night_start = datetime.datetime(year=year, month=month, day=day, hour=user.night_start.hour,
                                           minute=user.night_start.minute)
    user_night_end = user_night_start

    while True:
        if user_daytime_end.hour == user.daytime_end.hour and user_daytime_end.minute == user.daytime_end.minute:
            break

        user_daytime_end += datetime.timedelta(minutes=30)

    while True:
        if user_night_end.hour == user.night_end.hour and user_night_end.minute == user.night_end.minute:
            break

        user_night_end += datetime.timedelta(minutes=30)


    shift_start = datetime.datetime(year=year, month=month, day=day,
                                    hour=shift.start.hour,
                                    minute=shift.start.minute)
    shift_end = shift_start

    while True:
        if shift_end.hour == shift.end.hour and shift_end.minute == shift.end.minute:
            break
        shift_end += datetime.timedelta(minutes=30)


    shift_now = shift_start + datetime.timedelta(minutes=30)
    daytime_count = 0.0
    night_count = 0.0

    while shift_now <= shift_end:
        if user_daytime_start <= shift_now <= user_daytime_end:
            daytime_count += 0.5
        else:
            night_count += 0.5

        shift_now += datetime.timedelta(minutes=30)

    return user.daytime_wage * daytime_count + user.night_wage * night_count


def get_sunday(shift_update_date):
    if shift_update_date.weekday() == 6:
        return shift_update_date
    else:
        timedelta = abs((shift_update_date.weekday() * -1) - 1)
        return shift_update_date - datetime.timedelta(days=timedelta)
