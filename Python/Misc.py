from subprocess import Popen, PIPE
from collections import OrderedDict

class Notes:
    """A collection of python concepts"""

    @staticmethod
    def subprocess():
        """Runs bash command and get output"""
        process = Popen('ls /home/nelson/Projects/Git', stdout=PIPE, shell=True)
        out, err = process.communicate()
        print(out.decode())

    @staticmethod
    def orderedDict():
        """Sorts an ordered dict by key, with a custom key list, and with secondary sorting"""
        data = OrderedDict([('model 6', OrderedDict([('model', 'model 6'),
                                                     ('production status', 'flight-ready')])),
                            ('model 7', OrderedDict([('model', 'model 7'),
                                                     ('production status', 'flight-ready')])),
                            ('model 1', OrderedDict([('model', 'model 1'),
                                                     ('production status', 'in-production')])),
                            ('model 5', OrderedDict([('model', 'model 5'),
                                                     ('production status', 'flight-ready')])),
                            ('model 2', OrderedDict([('model', 'model 2'),
                                                     ('production status', 'announced')])),
                            ('model 4', OrderedDict([('model', 'model 4'),
                                                     ('production status', 'in-concept')])),
                            ('model 3', OrderedDict([('model', 'model 3'),
                                                     ('production status', 'flight-ready')]))])

        byModel = OrderedDict(sorted(data.items(), key=lambda item: item[0]))
        byProdStat = OrderedDict(sorted(data.items(), key=lambda item: ['flight-ready', 'hangar-ready', 'ready', 'in-production', 'in-concept', 'announced'].index(item[1]['production status'])))
        byProdStatWithSecondary = OrderedDict(sorted(data.items(), key=lambda item: (['flight-ready', 'hangar-ready', 'ready', 'in-production', 'in-concept', 'announced'].index(item[1]['production status']), item[0])))

        print('Primary sorted by Model:')
        for m in byModel.items():
            print(m)

        print('\nPrimary sorted by Production Status:')
        for p in byProdStat.items():
            print(p)
        
        print('\nPrimary sorted by Production Status, secondary sorted by Model:')
        for ps in byProdStatWithSecondary.items():
            print(ps)

if __name__ == '__main__':
    Notes.subprocess()
    Notes.orderedDict()
