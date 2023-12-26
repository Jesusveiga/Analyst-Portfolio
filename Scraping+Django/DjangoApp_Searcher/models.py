from django.db import models

class Property(models.Model):
    title = models.CharField(max_length=200)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    under_construction = models.BooleanField()
    location = models.CharField(max_length=200)
    square_meters = models.IntegerField(null=True, blank=True) 

    def __str__(self):
        return self.title