using Domain.Services;
using Domain.Services.Implementations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using WebApp.ViewModels;

namespace WebApp.Models.Facades
{
    public class CatalogoServiceFacade : ICatalogoServiceFacade
    {
        ICatalogoService catalogoService;

        public CatalogoServiceFacade()
        {
            catalogoService = new CatalogoService();
        }

        public IEnumerable<SelectViewModel> Listar_Grados()
        {
            var lista = catalogoService.Listar_Catalogo(Domain.Helpers.Parametro.Grado);

            var result = lista.Where(x => x.T_OpcionCod != "4" && x.T_OpcionCod != "5").Select(x => Mapper.CatalogoOpcionEntity_To_SelectViewModel(x)).ToList();

            return result;
        }

        public IEnumerable<SelectViewModel> Listar_Periodos()
        {
            var lista = catalogoService.Listar_Catalogo(Domain.Helpers.Parametro.Periodo);

            var result = lista.Select(x => Mapper.CatalogoOpcionEntity_To_SelectViewModel(x)).ToList();

            return result;
        }

        public IEnumerable<SelectViewModel> Listar_TipoPagos()
        {
            var lista = catalogoService.Listar_Catalogo(Domain.Helpers.Parametro.TipoPago);

            var result = lista.Select(x => Mapper.CatalogoOpcionEntity_To_SelectViewModel(x)).ToList();

            return result;
        }
    }
}