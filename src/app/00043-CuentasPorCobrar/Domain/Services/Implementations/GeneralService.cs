using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Domain.Helpers;

namespace Domain.Services.Implementations
{
    public class GeneralService : IGeneralService
    {
        public IEnumerable<int> Listar_Anios()
        {
            var lista = new List<int>();

            for (int i = DateTime.Now.Year + 1; 1963 < i; i--)
            {
                lista.Add(i);
            }

            return lista;
        }

        public IEnumerable<TipoEstudio> Listar_TipoEstudios()
        {
            var result = new List<TipoEstudio>();

            result.Add(TipoEstudio.Pregrado);

            result.Add(TipoEstudio.Posgrado);

            return result;
        }

        public IEnumerable<int> Listar_Horas()
        {
            var lista = new List<int>();

            for (int i = 0; i < 24; i++)
            {
                lista.Add(i);
            }

            return lista;
        }

        public IEnumerable<int> Listar_Minutos()
        {
            var lista = new List<int>();

            for (int i = 0; i < 60; i++)
            {
                lista.Add(i);
            }

            return lista;
        }
    }
}
