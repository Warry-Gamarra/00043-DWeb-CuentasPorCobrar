using Domain.Helpers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface IGeneralService
    {
        IEnumerable<int> Listar_Anios();

        IEnumerable<TipoEstudio> Listar_TipoEstudios();

        IEnumerable<int> Listar_Horas();

        IEnumerable<int> Listar_Minutos();
    }
}
