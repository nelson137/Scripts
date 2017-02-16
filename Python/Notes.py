import subprocess
from collections import OrderedDict

class Notes:
    '''A collection of complex python concepts'''
    def __init__(self):
        pass

    def subprocess(self):
        '''Runs bash command and get output'''
        process = subprocess.Popen(['ls', '/home/nelson137/Projects/Git'], stdout=subprocess.PIPE)
        self.out, self.err = process.communicate()
        print(self.out.decode())

    def orderedDict(self):
        '''Sorts an ordered dict by key, with a custom key list, and with secondary sorting'''
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

        self.byModel = OrderedDict(sorted(data.items(), key=lambda item: item[0]))
        self.byProdStat = OrderedDict(sorted(data.items(), key=lambda item: ['flight-ready', 'hangar-ready', 'ready', 'in-production', 'in-concept', 'announced'].index(item[1]['production status'])))
        self.byProdStatWithSecondary = OrderedDict(sorted(data.items(), key=lambda item: (['flight-ready', 'hangar-ready', 'ready', 'in-production', 'in-concept', 'announced'].index(item[1]['production status']), item[0])))

        for m in self.byModel.items():
            print(m)
        print()
        for p in self.byProdStat.items():
            print(p)
        print()
        for ps in self.byProdStatWithSecondary.items():
            print(ps)

if __name__ == '__main__':
    notes = Notes()