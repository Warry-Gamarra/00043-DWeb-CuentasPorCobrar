using Domain.Helpers;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services
{
    public interface IClasificadorEquivalencia
    {
        List<ClasificadorEquivalencia> Find(string anio);
        List<ClasificadorEquivalencia> Find(int clasificadorId);
        List<ClasificadorEquivalencia> Find(int clasificadorId, string anio);
        Response Save(ClasificadorEquivalencia clasificadorEquivalencia, int currentUserId, SaveOption saveOption);
        Response SaveAnio(ClasificadorEquivalencia clasificadorEquivalencia, string anio, int currentUserId, SaveOption saveOption);
    }
}
