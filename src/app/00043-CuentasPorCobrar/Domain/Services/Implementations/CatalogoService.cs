using Data.Tables;
using Domain.DTO;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Services.Implementations
{
    public class CatalogoService : ICatalogoService
    {
        public List<CatalogoOpcionEntity> Listar_Catalogo(Parametro parametro)
        {
            try
            {
                var lista = TC_CatalogoOpcion.FindByParametro((int)parametro);

                var result = lista.Where(x => x.B_Habilitado).
                    Select(x => Mapper.TC_CatalogoOpcion_To_CatalogoOpcionEntity(x)).ToList();

                return result;
            }
            catch (Exception ex)
            {
                return new List<CatalogoOpcionEntity>();
            }
        }
    }
}
